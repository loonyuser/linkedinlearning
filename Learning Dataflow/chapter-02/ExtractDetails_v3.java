
package org.loony.dataflow;

import java.lang.Double;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.TypeDescriptors;
import java.util.Collections;

public class ExtractDetails {

    private static final String CSV_HEADER = "Order_ID,Product,Quantity_Ordered,Price_Each,Order_Date,Purchase_Address";

    public static void main(String[] args) {

        SalesDetailsOptions options =
            PipelineOptionsFactory.fromArgs(args)
                                  .withValidation()
                                  .as(SalesDetailsOptions.class);
        
        runProductDetails(options);
    }

    public interface SalesDetailsOptions extends PipelineOptions {

        @Description("Path of the file to read from")
        @Default.String("gs://loony-ll-bucket/input_data/Sales_April_2019.csv")
        String getInputFile();

        void setInputFile(String value);

        @Description("Path of the file to write to")
        @Default.String("gs://loony-ll-bucket/output_data/output_sales_details")
        String getOutputFile();

        void setOutputFile(String value);
    }
    
    static void runProductDetails(SalesDetailsOptions options) {
        
        Pipeline p = Pipeline.create(options);
    
        p.apply("ReadLines", TextIO.read().from(options.getInputFile()))
            .apply(ParDo.of(new FilterHeaderFn(CSV_HEADER)))
            .apply("ExtractProductCount", FlatMapElements
                        .into(TypeDescriptors.strings())
                        .via((String row) -> Collections.singletonList(row.split(",")[1])))
                        .apply("CountAggregation", Count.perElement())
            .apply("FormatResult", MapElements
                        .into(TypeDescriptors.strings())
                        .via((KV<String, Long> typeCount) ->
                                typeCount. getKey() + "," + typeCount.getValue()))
            .apply("WriteSalesDetails", TextIO.write().to(options.getOutputFile())
                                                .withHeader("Product,Count")
                                                .withoutSharding()
                                                .withSuffix(".csv"));

        p.run().waitUntilFinish();
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

    static class ExtractSalesDetailsFn extends DoFn<String, String> {

        @ProcessElement
        public void processElement(@Element String element, OutputReceiver<String> receiver) {
        
        String[] field = element.split(",");
        
        String productDetails = field[1] + "," + 
            Double.toString(Integer.parseInt(field[2]) * Double.parseDouble(field[3])) + "," +  field[4];
                
        receiver.output(productDetails);
        }
    }
}
