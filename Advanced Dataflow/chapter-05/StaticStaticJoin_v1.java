package org.loony.dataflow;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.values.*;
import org.apache.beam.sdk.extensions.joinlibrary.Join;


public class StaticStaticJoin {

    private static final String MOVIES_HEADER = "Series_Title,Released_Year,IMDB_Rating,Meta_score,No_of_Votes";
    private static final String DIRECTORS_HEADER = "Series_Title,Director,Star1,Star2,Star3,Star4";

    public static void main(String[] args) {
        
        PipelineOptions options = PipelineOptionsFactory.create();
        Pipeline pipeline = Pipeline.create(options);

        PCollection<KV<String, String>> directors = pipeline
                .apply(TextIO.read().from("gs://loony-ll-bucket/join_data/directors.csv"))
                .apply("FilterDirectorHeader", ParDo.of(new FilterHeaderFn(DIRECTORS_HEADER)))
                .apply("TitleDirectorKV", ParDo.of(new TitleDirectorKVFn()));

        PCollection<KV<String, Double>> movies = pipeline
                .apply(TextIO.read().from("gs://loony-ll-bucket/join_data/movies.csv"))
                .apply("FilterMovieHeader", ParDo.of(new FilterHeaderFn(MOVIES_HEADER)))
                .apply("TitleRatingKV", ParDo.of(new TitleRatingKVFn()));

        PCollection<KV<String, KV<String, Double>>> joinedDatasets = Join.innerJoin(
            directors, movies);

        joinedDatasets.apply(MapElements.via(
                new SimpleFunction<KV<String, KV<String, Double>>, Void>() {

            @Override
            public Void apply(KV<String, KV<String, Double>> input) {
                System.out.println(input.getKey() + ", " +
                        input.getValue().getKey() + ", " + input.getValue().getValue());
                return null;
            }

        }));

        pipeline.run().waitUntilFinish();

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

    private static class TitleDirectorKVFn extends DoFn<String, KV<String, String>> {

        @ProcessElement
        public void processElement(
                @Element String element,
                OutputReceiver<KV<String, String>> out) {
            String[] fields = element.split(",");

            String title = fields[0];
            String director = fields[1];

            out.output(KV.of(title, director));
        }
    }

}