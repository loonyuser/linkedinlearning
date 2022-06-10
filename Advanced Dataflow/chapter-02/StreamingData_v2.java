package org.loony.dataflow;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.*;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.KV;
import org.joda.time.Duration;


public class StreamingData {

    private static final String CSV_HEADER =
            "Make,Type,Year,Origin,Color,Options,Engine_Size,Fuel_Type,Gear_Type,Mileage,Region,Price,Negotiable";

    public interface StreamingDataOptions extends PipelineOptions {

        @Description("Path of the file to read from")
        @Default.String("gs://loony-ll-bucket/streaming_data/*.csv")
        String getInputFile();

        void setInputFile(String value);
    } 
    public static void main(String[] args) {
        
        StreamingDataOptions options = PipelineOptionsFactory.as(StreamingDataOptions.class);
        Pipeline pipeline = Pipeline.create(options);

        pipeline.apply("StreamFiles", TextIO.read().from(options.getInputFile())
                    .watchForNewFiles(Duration.standardSeconds(30),
                            Watch.Growth.afterTimeSinceNewOutput(Duration.standardSeconds(300))))
                .apply("FilterHeader", ParDo.of(new FilterHeaderFn(CSV_HEADER)))
                .apply("MakePriceKVFn", ParDo.of(new MakePriceKVFn()))
                .apply("PrintToConsole", ParDo.of(new DoFn<KV<String, Integer>, Void>() {

                    private static final long serialVersionUID = 1L;

                    @ProcessElement
                    public void processElement(ProcessContext c) {
                        System.out.println(c.element().getKey() + ": " + c.element().getValue());
                    }
                }));

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

    private static class MakePriceKVFn extends DoFn<String, KV<String, Integer>> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(ProcessContext c) {
            String[] fields = c.element().split(",");

            String makeAndModel = fields[0] + " " + fields[1];

            int price = Integer.parseInt(fields[11]);

            c.output(KV.of(makeAndModel, price));
        }
    }
}
