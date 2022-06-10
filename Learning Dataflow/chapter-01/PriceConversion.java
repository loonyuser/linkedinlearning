package org.loony.dataflow;

import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.transforms.SimpleFunction;
import java.util.List;
import java.util.Arrays;

public class PriceConversion{

	private static final int USD_JPY = 130; 

	public static class ConverterUSDtoJPY extends DoFn<Double, Integer>{

		@ProcessElement
		public void processElement(ProcessContext c){
			c.output(Double.valueOf(USD_JPY * c.element()).intValue());
		}
	}

	public static void main(String[] args) {

        PipelineOptions options = PipelineOptionsFactory.create();
        Pipeline p = Pipeline.create(options);

        List<Double> productPrices = Arrays.asList(143.21, 34.59, 78.90, 
                                                238.17, 649.99, 320.14);

        p.apply(Create.of(productPrices))
        .apply(ParDo.of(new ConverterUSDtoJPY()))
        .apply(MapElements.via(new SimpleFunction<Integer, Void>() {
            @Override
            public Void apply(Integer input){
                System.out.println("Transformed price: " + input);
                return null;
            }
        }));

        p.run();

    }
}

