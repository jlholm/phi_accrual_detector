# frozen_string_literal: true

require "phi_accrual/atomic/fixnum"

module PhiAccrual
  class HeartbeatHistory
    def initialize(max_sample_size:)
      if max_sample_size < 1
        raise ArgumentError, "max_sample_size must be >= 1, got #{max_sample_size}"
      end

      @max_sample_size = max_sample_size
      @intervals = Queue.new
      @interval_sum = Atomic::Fixnum.new(value: 0)
      @squared_interval_sum = Atomic::Fixnum.new(value: 0)
    end

    def add(interval)
      if intervals.length >= @max_sample_size
        dropped = intervals.pop
        interval_sum.add(-dropped)
        squared_interval_sum.add(-pow2(dropped))
      end

      intervals.push(interval)
      interval_sum.add(interval)
      squared_interval_sum.add(pow2(interval))

      self
    end

    def mean
      return if intervals.length.zero?

      (interval_sum.value / intervals.length)
    end

    def variance
      return if intervals.length.zero?

      (squared_interval_sum.value / intervals.length) - (mean * mean)
    end

    def std_deviation
      return if variance.nil?

      Math.sqrt(variance)
    end

    private

    attr_reader :intervals, :interval_sum, :squared_interval_sum

    def pow2(x)
      (x * x)
    end
  end
end
