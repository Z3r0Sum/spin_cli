require 'colorize'
require 'hashdiff'

module SpinCli
  module Utils
    class Pipeline
      def self.compare(existing_pipeline_json, updated_pipeline_json)
        puts "The following changes will take place:\n\n"
        diff = HashDiff.diff(existing_pipeline_json, updated_pipeline_json)

        diff.each do |change|
          next if change.include?('id') || change.include?('lastModifiedBy') || \
                  change.include?('index') || change.include?('updateTs')
          if change[0] == '+'
            convert_diff(change, :yellow)
          elsif change[0] == '-'
            convert_diff(change, :red)
          elsif change[0] == '~'
            convert_diff(change, :cyan)
          else
            puts "Unable to detect type of change: #{change}"
          end
        end
      end

      def self.convert_diff(changes, color)
        change_type = changes.shift
        change_hash = {}
        change_hash[changes.shift] = changes

        puts "#{change_type} #{JSON.pretty_generate(change_hash)}".colorize(color)
      end
    end
  end
end
