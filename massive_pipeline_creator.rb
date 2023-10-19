require 'yaml'
require 'json'

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
      json = { steps: steps_chunk }

      output_file_name = "pipeline.chunk-#{index}.yml"

      File.open(output_file_name, "w") { |file| file.write YAML.dump(JSON.parse(json.to_json)) }

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

# Buildkite limits step uploads to 500 steps per pipeline file. From the documentation:
#
# > You can also pipe build pipelines to the command allowing you to create scripts that
# generate dynamic pipelines. The configuration file has a limit of 500 steps per file.
# Configuration files with over 500 steps must be split into multiple files and uploaded
# in separate steps.
#
# This script creates a pipeline with 1250 steps, and splits it into 3 files (500, 500, 250).
MassivePipelineCreator.create(steps_count: 1250, step_chunk_size: 500)
