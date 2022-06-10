package org.loony.dataflow;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.*;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.KV;
import org.joda.time.Duration;
import org.apache.beam.sdk.transforms.windowing.Window;
import org.apache.beam.sdk.transforms.windowing.FixedWindows;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;


public class StreamingData {

    private static final String CSV_HEADER =
            "Make,Type,Year,Origin,Color,Options,Engine_Size,Fuel_Type,Gear_Type,Mileage,Region,Price,Negotiable";

    public interface StreamingDataOptions extends PipelineOptions {

        @Description("Path of the file to read from")
        @Validation.Required
        String getInputFilesLocation();
        void setInputFilesLocation(String value);

        @Description("PubSub topic to write to")
        @Validation.Required
        String getTopicName();
        void setTopicName(String value);
    } 
    public static void main(String[] args) {
        
        StreamingDataOptions options = PipelineOptionsFactory.fromArgs(args).withValidation()
                .as(StreamingDataOptions.class);

        Pipeline pipeline = Pipeline.create(options);

        pipeline.apply("StreamFiles", TextIO.read().from(options.getInputFilesLocation())
                    .watchForNewFiles(Duration.standardSeconds(30),
                            Watch.Growth.afterTimeSinceNewOutput(Duration.standardSeconds(300))))
                .apply("Window", Window.into(FixedWindows.of(Duration.standardSeconds(120))))
                .apply("FilterHeaderFn", ParDo.of(new FilterHeaderFn(CSV_HEADER)))
                .apply("MakePriceKVFn", ParDo.of(new MakePriceKVFn()))
                .apply("MakeGrouping", GroupByKey.create())
                .apply("ComputeAveragePrice", ParDo.of(new ComputeAveragePriceFn())) 
                .apply("CreatePubSubMessage", ParDo.of(new ConvertToMessage()))  
                .apply("WriteToPubSub", PubsubIO.writeStrings().to(
                        "projects/loony-learn/topics/" + options.getTopicName()));

        pipeline.run().waitUntilFinish();
    }

    private static class FilterHeaderFn extends DoFn<String, String> {

        private static final long serialVersionUID = 1L;
        private final String header;

        public FilterHeaderFn(String header) {
            this.header = header;
        }

        @ProcessElement
        public void processElement(ProcessContext c) {
            String row = c.element();

            if (!row.isEmpty() && !row.equals(this.header)) {
                c.output(row);
            }
        }
    }

    private static class MakePriceKVFn extends DoFn<String, KV<String, Double>> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(ProcessContext c) {
            String[] fields = c.element().split(",");

            String make = fields[0];
            Double price = Double.parseDouble(fields[11]);

            c.output(KV.of(make, price));
        }
    }

    private static class ComputeAveragePriceFn extends
            DoFn<KV<String, Iterable<Double>>, KV<String, Double>> {

        private static final long serialVersionUID = 1L;
                
        @ProcessElement
        public void processElement(
                @Element KV<String, Iterable<Double>> element,
                OutputReceiver<KV<String, Double>> out) {

            String make = element.getKey();

            int count = 0;
            double sumPrice = 0;

            for (Double price: element.getValue()) {
                sumPrice +=  price;
                count++;
            }

            out.output(KV.of(make, sumPrice / count));
        }
    }

    public static class ConvertToMessage extends DoFn<KV<String, Double>, String> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(DoFn<KV<String, Double>, String>.ProcessContext c) {
            c.output("{\"Make\": \"" + c.element().getKey() 
                     + "\", \"AvgPrice\": " + c.element().getValue() + "}");
        }
    }
}
