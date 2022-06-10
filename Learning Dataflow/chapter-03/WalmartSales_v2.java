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
                .apply("StoreSalesKVFn", ParDo.of(new StoreSalesKVFn()))
                .apply("MakeGrouping", GroupByKey.create())
                .apply("ComputeAverageSalesFn", ParDo.of(new ComputeAverageSalesFn()))
                .apply("FormatResult", MapElements
                        .into(TypeDescriptors.strings())
                        .via((KV<Integer, Double> avgSales) ->
                        avgSales.getKey() + "," + avgSales.getValue())) 
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

    private static class StoreSalesKVFn extends DoFn<String, KV<Integer, Double>> {

        @ProcessElement
        public void processElement(ProcessContext c) {
            String[] fields = c.element().split(",");

            Integer store = Integer.parseInt(fields[0]);
            Double sales = Double.parseDouble(fields[2]);

            c.output(KV.of(store, sales));
        }
    }

    private static class ComputeAverageSalesFn extends
            DoFn<KV<Integer, Iterable<Double>>, KV<Integer, Double>> {

        @ProcessElement
        public void processElement(
                @Element KV<Integer, Iterable<Double>> element,
                OutputReceiver<KV<Integer, Double>> out) {

                Integer store = element.getKey();

            int count = 0;
            double sumSales = 0;

            for (Double weeklySales: element.getValue()) {
                sumSales +=  weeklySales;
                count++;
            }

            out.output(KV.of(store, sumSales / count));
        }
    }
}


