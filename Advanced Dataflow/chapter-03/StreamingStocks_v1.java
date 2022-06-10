package org.loony.dataflow;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.options.*;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class StreamingStocks {

    public static final String INDEX_NAME = "index";
    public static final String LTP = "ltp";

    private static final Logger log = LoggerFactory.getLogger(StreamingStocks.class);

    public interface PubSubReadOptions extends StreamingOptions {
        
        @Description("The Cloud Pub/Sub topic to read from.")
        @Validation.Required
        String getInputTopic();
        void setInputTopic(String value);

    }

    public static void main(String[] args) {

        PubSubReadOptions options = PipelineOptionsFactory.fromArgs(args).withValidation()
                .as(PubSubReadOptions.class);

        streamingStockData(options);
    }

    private static void streamingStockData(PubSubReadOptions options) {

        options.setStreaming(true);

        Pipeline pipeline = Pipeline.create(options);

        pipeline.apply("ReadingFromPubSub", PubsubIO.readStrings()
                        .fromTopic(options.getInputTopic()))
                .apply("ExtractStockData", ParDo.of(new ConvertToKV()))
                .apply("PrintToConsole", ParDo.of(new DoFn<KV<String, Double>, Void>() {

                    private static final long serialVersionUID = 1L;

                    @ProcessElement
                    public void processElement(ProcessContext c) {
                        log.info(c.element().getKey() + ": " + c.element().getValue());
                    }
                }));
                

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

}
