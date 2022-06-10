package org.loony.dataflow;

import java.io.IOException;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.*;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.StreamingOptions;
import org.apache.beam.sdk.options.Validation;
import org.apache.beam.sdk.transforms.windowing.FixedWindows;
import org.apache.beam.sdk.transforms.windowing.Window;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.PCollection;

import org.apache.beam.sdk.extensions.joinlibrary.Join;

import org.joda.time.Duration;

public class StreamStreamJoin {

    public interface PubSubToGcsOptions extends StreamingOptions {

        @Description("The Cloud Pub/Sub first topic to read from.")
        @Validation.Required
        String getInputTopicActors();
        void setInputTopicActors(String value);

        @Description("The Cloud Pub/Sub second topic to read from.")
        @Validation.Required
        String getInputTopicMovies();
        void setInputTopicMovies(String value);
        
        @Description("Path of the output file including its filename prefix.")
        @Validation.Required
        String getOutput();
        void setOutput(String value);

      }
    
      public static void main(String[] args) throws IOException {
    
        PubSubToGcsOptions options =
            PipelineOptionsFactory.fromArgs(args).withValidation().as(PubSubToGcsOptions.class);
    
        options.setStreaming(true);
    
        Pipeline pipeline = Pipeline.create(options);

        PCollection<KV<String,String>> actorsInfo = pipeline
                .apply("Read Actor Details", PubsubIO.readStrings().fromTopic(options.getInputTopicActors()))
                .apply("Window", Window.into(FixedWindows.of(Duration.standardSeconds(40))))
                .apply("TitleActorsKVFn", ParDo.of(new TitleActorsKVFn()));

        PCollection<KV<String, Double>> moviesInfo = pipeline
                .apply("Read Movie Details", PubsubIO.readStrings().fromTopic(options.getInputTopicMovies()))
                .apply("Window", Window.into(FixedWindows.of(Duration.standardSeconds(40))))
                .apply("TitleRatingKVFn", ParDo.of(new TitleRatingKVFn()));  


        PCollection<KV<String, KV<String, Double>>> movieWithActorInfo = Join.innerJoin(actorsInfo, moviesInfo);

        movieWithActorInfo.apply("ConvertToString", MapElements
                .into(TypeDescriptors.strings())
                .via((KV<String, KV<String, Double>> data) -> 
                        data.getKey() + "," + data.getValue().getKey() + "," + data.getValue().getValue()))

                .apply("WriteToBucket", TextIO.write().to(options.getOutput())
                                                .withWindowedWrites()
                                                .withoutSharding());        
    
        pipeline.run().waitUntilFinish();
      }

    private static class TitleRatingKVFn extends DoFn<String, KV<String, Double>> {

        @ProcessElement
        public void processElement(
                @Element String element,
                OutputReceiver<KV<String, Double>> out) {
            String[] fields = element.split(",");

            String title = fields[0];
            Double rating = Double.parseDouble(fields[2]);

            out.output(KV.of(title, rating));
        }
    }

    private static class TitleActorsKVFn extends DoFn<String, KV<String, String>> {

        @ProcessElement
        public void processElement(
                @Element String element,
                OutputReceiver<KV<String, String>> out) {
            String[] fields = element.split(",");

            String title = fields[0];
            String actors = fields[2] + " , " + fields[3] ;

            out.output(KV.of(title, actors));
        }
    }
}