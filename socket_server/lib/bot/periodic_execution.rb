module PeriodicExecution
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  def fork_periodic_tasks
    return unless periodic_tasks

    periodic_tasks.each do |seconds, task_block|
      within_subprocess do
        loop do
          instance_eval &task_block
          sleep seconds
        end
      end
    end
  end

  def periodic_tasks
    self.class.instance_variable_get(:"@periodic_tasks")
  end

  module ClassMethods
    def periodically(seconds, &block)
      @periodic_tasks ||= []
      @periodic_tasks << [seconds, block]
    end
  end
end
