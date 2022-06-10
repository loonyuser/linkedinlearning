package org.loony.dataflow;

import java.util.ArrayList;
import org.json.JSONObject;

import com.google.api.services.bigquery.model.TableFieldSchema;
import com.google.api.services.bigquery.model.TableRow;
import com.google.api.services.bigquery.model.TableSchema;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.options.*;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;

import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.transforms.GroupByKey;
import org.apache.beam.sdk.transforms.windowing.FixedWindows;
import org.apache.beam.sdk.transforms.windowing.TimestampCombiner;
import org.apache.beam.sdk.transforms.windowing.Window;

import org.joda.time.Duration;


public class StreamingStocks {

    public static final String INDEX_NAME = "index";
    public static final String LTP = "ltp";
    public static final String DATETIME = "time";
    public static final String AVERAGE_PRICE = "average_price";


    public interface PubSubReadOptions extends StreamingOptions {
        
        @Description("The Cloud Pub/Sub topic to read from.")
        @Validation.Required
        String getInputTopic();
        void setInputTopic(String value);

        @Description("The BigQuery table to write to.")
        @Validation.Required
        String getDestTableName();
        void setDestTableName(String value);

        @Description("Output file's window size in number of seconds.")
        @Default.Integer(30)
        Integer getWindowSize();
        void setWindowSize(Integer value);

    }

    public static void main(String[] args) {

        PubSubReadOptions options = PipelineOptionsFactory.fromArgs(args).withValidation()
                .as(PubSubReadOptions.class);

        streamingStockData(options);
    }

    private static void streamingStockData(PubSubReadOptions options) {

        options.setStreaming(true);

        Pipeline pipeline = Pipeline.create(options);

        PCollection<String> pubSubMessages = pipeline.apply(PubsubIO.readStrings()
            .fromTopic(options.getInputTopic())
            .withTimestampAttribute(DATETIME));

            pubSubMessages.apply("ApplyWindow", Window.<String>into(FixedWindows.of(
                Duration.standardSeconds(options.getWindowSize())))
                .withTimestampCombiner(TimestampCombiner.EARLIEST))
                .apply("ExtractStockData", ParDo.of(new ConvertToKV()))
                .apply("GroupByKeys", GroupByKey.create())
                .apply("CalculateAverage", ParDo.of(new Average()))
                .apply("ConvertToTableRows", ParDo.of(new ConvertToTableRow()))
                .apply("WriteToBigQuery", BigQueryIO.writeTableRows()
                            .to("loony-learn:stock_data." + options.getDestTableName())
                        .withSchema(ConvertToTableRow.getSchema())
                        .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_IF_NEEDED)
                        .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_APPEND));
                

        pipeline.run().waitUntilFinish();
    }

    public static class ConvertToKV extends DoFn<String, KV<String, Double>> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(DoFn<String, KV<String, Double>>.ProcessContext c) {
            JSONObject obj = new JSONObject(c.element());

            c.output(KV.of(obj.getString(INDEX_NAME), 
                           obj.getDouble(LTP)));
        }
    }

    public static class Average extends DoFn<KV<String, Iterable<Double>>, KV<String, Double>> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(DoFn<KV<String, Iterable<Double>>, KV<String, Double>>.ProcessContext c) {
            double total = 0;
            int n = 0;
            
            for (Double i : c.element().getValue()) {
                total += i;
                n++;
            }
            Double average = total / n;

            c.output(KV.of(c.element().getKey(), average));
        }
    }

    public static class ConvertToTableRow extends DoFn<KV<String, Double>, TableRow> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(DoFn<KV<String, Double>, TableRow>.ProcessContext c) {

            String dateTime = c.timestamp().toString();
            c.output(new TableRow()
                    .set(DATETIME, dateTime.substring(0, dateTime.length() - 1))
                    .set(INDEX_NAME, c.element().getKey())
                    .set(AVERAGE_PRICE, c.element().getValue()));
        }

        public static TableSchema getSchema() {
            return new TableSchema().setFields(new ArrayList<TableFieldSchema>() {
                {
                    add(new TableFieldSchema().setName(DATETIME).setType("DATETIME"));
                    add(new TableFieldSchema().setName(INDEX_NAME).setType("STRING"));
                    add(new TableFieldSchema().setName(AVERAGE_PRICE).setType("FLOAT"));

                }
            });
        }
    }

}
