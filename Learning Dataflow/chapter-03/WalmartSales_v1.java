package org.loony.dataflow;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.TypeDescriptors;

public class WalmartSales {

    private static final String CSV_HEADER = "Store,Date,Weekly_Sales,Holiday_Flag,"
                                            + "Temperature,Fuel_Price,CPI,Unemployment";

    public static void main(String[] args) {
        StoreSalesAvgOptions options =
                PipelineOptionsFactory.fromArgs(args).withValidation().as(StoreSalesAvgOptions.class);

        runStoreSales(options);
    }

    public interface StoreSalesAvgOptions extends PipelineOptions {

        @Description("Path of the file to read from")
        @Default.String("gs://loony-ll-bucket/input_data/Walmart.csv")
        String getInputFile();

        void setInputFile(String value);

        @Description("Path of the file to write to")
        @Default.String("gs://loony-ll-bucket/output_data/WalmartStoreAvg")
        String getOutputFile();

        void setOutputFile(String value);
    }

    static void runStoreSales(StoreSalesAvgOptions options) {
        Pipeline p = Pipeline.create(options);

        p.apply("ReadLines", TextIO.read().from(options.getInputFile()))
                .apply(ParDo.of(new FilterHeaderFn(CSV_HEADER)))
                .apply("ExtractStoreDetails", ParDo.of(new ExtractStoreDetails()))
                .apply("AvgSalesOfStore", Mean.perKey())
                .apply("FormatResult", MapElements
                        .into(TypeDescriptors.strings())
                        .via((KV<String, Double> meanSales) ->
                                meanSales.getKey() + "," + meanSales.getValue()))                
                .apply("WriteResultOnOutputPath", TextIO.write().to(options.getOutputFile())
                .withoutSharding()
                .withSuffix(".csv")
                .withShardNameTemplate("-SSS")
                .withHeader("StoreId, AvgSales"));

        p.run().waitUntilFinish();
    }
    
    private static class FilterHeaderFn extends DoFn<String, String> {

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

    private static class ExtractStoreDetails extends DoFn<String, KV<String, Double>> {
        @ProcessElement

        public void processElement(@Element String element, OutputReceiver<KV<String, Double>> receiver) {

            String[] data = element.split(",");

            Double weeklySales = Double.parseDouble(data[2]);
            String storeId = data[0];

            KV<String, Double> pair = KV.<String, Double>of(storeId, weeklySales);

            receiver.output(pair);
        }

    }
}


