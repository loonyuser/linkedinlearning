package org.apache.beam.mydataflowexamples;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.*;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.TypeDescriptors;
import org.joda.time.Duration;
import java.util.Calendar;

public class StreamingData {

    private static final String CSV_HEADER =
            "Make,Type,Year,Origin,Color,Options,Engine_Size,Fuel_Type,Gear_Type,Mileage,Region,Price,Negotiable";

    public interface StreamingDataOptions extends PipelineOptions {

        @Description("Path of the file to read from")
        @Default.String("gs://loony-ll-dataflow-storage/streaming_data/*.csv")
        String getInputFile();

        void setInputFile(String value);
    }            
    public static void main(String[] args) {
        
        StreamingDataOptions options = PipelineOptionsFactory.fromArgs(args).withValidation()
                .as(StreamingDataOptions.class);

        Pipeline pipeline = Pipeline.create(options);

        pipeline.apply("StreamFiles", TextIO.read().from(options.getInputFile())
                    .watchForNewFiles(Duration.standardSeconds(10),
                            Watch.Growth.afterTimeSinceNewOutput(Duration.standardSeconds(30))))
                .apply("FilterHeaderFn", ParDo.of(new FilterHeaderFn(CSV_HEADER)))
                .apply("MakeAgeKVFn", ParDo.of(new MakeAgeKVFn()))
                .apply("AvgAgeOfCar", Mean.perKey())
                .apply("FormatResult", MapElements
                        .into(TypeDescriptors.strings())
                        .via((KV<String, Double> meanAge) ->
                                meanAge.getKey() + "," + meanAge.getValue()))   
                .apply("PrintToConsole", ParDo.of(new DoFn<String, Void>() {

                    private static final long serialVersionUID = 1L;
                    @ProcessElement
                    public void processElement(ProcessContext c)  {
                        System.out.println(c.element());
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

    private static class MakeAgeKVFn extends DoFn<String, KV<String, Integer>> {

        private static final long serialVersionUID = 1L;

        @ProcessElement
        public void processElement(ProcessContext c) {
            String[] fields = c.element().split(",");

            String make = fields[0];

            int currentYear = Calendar.getInstance().get(Calendar.YEAR);
            int age = currentYear - Integer.parseInt(fields[2]);

            c.output(KV.of(make, age));
        }
    }
}