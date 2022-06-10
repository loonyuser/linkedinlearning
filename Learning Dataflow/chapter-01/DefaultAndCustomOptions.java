package org.loony.dataflow;

import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;

public class DefaultAndCustomOptions {

    public interface MyFirstCustomOption extends PipelineOptions {
        @Description("The signature of the pipeline")
        @Default.String("Dataflow Tutorial")
        String getSignature();
        void setSignature(String signature);
    }

    public static void main(String[] args) {
        PipelineOptionsFactory.register(MyFirstCustomOption.class);

        MyFirstCustomOption option = PipelineOptionsFactory.fromArgs(args).as(MyFirstCustomOption.class);
        
        System.out.println("Signature: " + option.getSignature());
        System.out.println("Runner: " + option.getRunner().getName());
        System.out.println("JobName: " + option.getJobName());
        System.out.println("UserAgent: " + option.getUserAgent());
    }
}
