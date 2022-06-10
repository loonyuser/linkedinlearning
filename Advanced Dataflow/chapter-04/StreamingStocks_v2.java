package org.loony.dataflow;

import java.util.ArrayList;
import org.json.JSONObject;

import com.google.api.services.bigquery.model.TableFieldSchema;
import com.google.api.services.bigquery.model.TableRow;
import com.google.api.services.bigquery.model.TableSchema;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.options.*;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;

import org.apache.beam.sdk.values.PCollection;


public class StreamingStocks {

    public static final String INDEX_NAME = "index";
    public static final String LTP = "ltp";
    public static final String DATETIME = "time";

    public interface PubSubToBqOptions extends StreamingOptions {
       
        @Description("The Cloud Pub/Sub topic to read from.")
        @Validation.Required
        String getInputTopic();
        void setInputTopic(String value);

        @Description("The BigQuery table to write to.")
        @Validation.Required
        String getDestTableName();
        void setDestTableName(String value);
    }

    public static void main(String[] args) {

        PubSubToBqOptions options = PipelineOptionsFactory.fromArgs(args).withValidation()
                .as(PubSubToBqOptions.class);

        streamingStockData(options);
    }

    private static void streamingStockData(PubSubToBqOptions options) {

        options.setStreaming(true);

        Pipeline pipeline = Pipeline.create(options);

        PCollection<String> pubSubMessages = pipeline.apply(PubsubIO.readStrings()
            .fromTopic(options.getInputTopic())
            .withTimestampAttribute(DATETIME));
        
        pubSubMessages.apply("RawDataToTableRow", ParDo.of(new ConvertToRawTableRow()))
                .apply("WriteRawDataToBigQuery", BigQueryIO.writeTableRows()
                    .to("loony-learn:stock_data." + options.getDestTableName())
                .withSchema(ConvertToRawTableRow.getSchema())
                .withCreateDisposition(BigQueryIO.Write.CreateDisposition.CREATE_IF_NEEDED)
                .withWriteDisposition(BigQueryIO.Write.WriteDisposition.WRITE_APPEND));
        
        pipeline.run().waitUntilFinish();
    }

    public static class ConvertToRawTableRow extends DoFn<String, TableRow> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(DoFn<String, TableRow>.ProcessContext c) {
            String input = c.element();

            JSONObject obj = new JSONObject(input);
            String dateTime = c.timestamp().toString();
            c.output(new TableRow()
                    .set(DATETIME, dateTime.substring(0, dateTime.length() - 1))
                    .set(INDEX_NAME, obj.getString(INDEX_NAME))
                    .set(LTP, obj.getDouble(LTP))
            );
        }

        public static TableSchema getSchema() {
            return new TableSchema().setFields(new ArrayList<TableFieldSchema>() {
                {
                    add(new TableFieldSchema().setName(DATETIME).setType("DATETIME"));
                    add(new TableFieldSchema().setName(INDEX_NAME).setType("STRING"));
                    add(new TableFieldSchema().setName(LTP).setType("NUMERIC"));
                }
            });
        }
    }
}
