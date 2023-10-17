require 'yaml'
require 'erb'
require 'json'

# Customers tell us they've split pipeline upload into 500 step chunks.
# This is a script to create a massive pipeline with multiple step chunks.
class MassivePipelineCreator
  def self.create(...)
    new.create(...)
  end

  def create(steps_count:, step_chunk_size:)
    number_of_pipeline_chunks = (steps_count.to_f / step_chunk_size.to_f).ceil
    steps = steps_count.times.map do |iteration|
      {
        name: "Step #{iteration + 1}",
        key: "step_#{iteration + 1}",
        command: "echo 'Step #{iteration + 1}'"
      }.tap do |step|
        step["depends_on"] = "step_#{iteration}" if iteration > 0
      end
    end

    steps.each_slice(step_chunk_size).with_index do |steps_chunk, index|
      output_file_contents = <<~ERB
        steps: <%= steps_chunk.to_json %>
      ERB

      file_contents = ERB.new(output_file_contents).result(binding)

      json = YAML.load(file_contents)

      output_file_name = "pipeline.chunk-#{index}.yml"

      File.open(output_file_name, "w") do |f|
        f.write json.to_yaml
      end

      system!("buildkite-agent", "pipeline", "upload", output_file_name)
    end
  end

  def system!(*command, **kwargs)
    verbose_command = command.join(" ")
    puts "\e[2m$\e[0m #{verbose_command}"
    system(*command, **kwargs) or raise "#{command.inspect} command failed: #{$?}"
    puts
  end
end

MassivePipelineCreator.create(steps_count: 1250, step_chunk_size: 500)
