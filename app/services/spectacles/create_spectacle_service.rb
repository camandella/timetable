module Spectacles
  class CreateSpectacleService
    @@mutex = Mutex.new

    attr_reader :errors, :spectacle

    def initialize
      reset_instance_variables
    end

    def perform(name, start_date, finish_date)
      range = Date.parse(start_date) .. Date.parse(finish_date) rescue nil
      spectacle = Spectacle.new(name: name, range: range)
      unless spectacle.valid?
        @errors = spectacle.errors.messages
        return false
      end

      thread = Thread.new do
        @@mutex.lock
        if Spectacle.find_by('range && daterange(?::date,?::date)', spectacle.start_date, spectacle.finish_date)
          @errors = spectacle.errors.tap do |spectacle_errors|
            spectacle_errors.add(:range, :crossing_ranges)
          end.messages
        else
          @spectacle = spectacle.tap { |spectacle| spectacle.save }
        end
        @@mutex.unlock
      end
      thread.join
      @errors.empty?
    end

    private

    def reset_instance_variables
      @errors = {}
      @spectacle = nil
    end
  end
end
