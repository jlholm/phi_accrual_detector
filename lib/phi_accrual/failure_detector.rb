# frozen_string_literal: true

require "phi_accrual/heartbeat_history"

module PhiAccrual
  class FailureDetector
    def initialize(
      threshold: 16.0,
      max_sample_size: 200,
      min_std_deviation_ms: 500,
      acceptable_heartbeat_pause_ms: 0,
      first_heartbeat_estimate_ms: 500
    )
      if threshold <= 0
        raise ArgumentError,
          "threshold must be > 0, got #{threshold}"
      end

      if max_sample_size <= 0
        raise ArgumentError,
          "max_sample_size must be > 0, got #{max_sample_size}"
      end

      if min_std_deviation_ms <= 0
        raise ArgumentError,
          "min_std_deviation_ms must be > 0, got #{min_std_deviation_ms}"
      end

      if acceptable_heartbeat_pause_ms < 0
        raise ArgumentError,
          "acceptable_heartbeat_pause_ms must be >= 0, got #{acceptable_heartbeat_pause_ms}"
      end

      if first_heartbeat_estimate_ms <= 0
        raise ArgumentError,
          "first_heartbeat_estimate_ms must be > 0, got #{first_heartbeat_estimate_ms}"
      end

      @threshold = threshold
      @max_sample_size = max_sample_size
      @min_std_deviation_ms = min_std_deviation_ms
      @std_deviation_ms = (first_heartbeat_estimate_ms / 4)
      @acceptable_heartbeat_pause_ms = acceptable_heartbeat_pause_ms
      @first_heartbeat_estimate_ms = first_heartbeat_estimate_ms

      @heartbeat_history = HeartbeatHistory.new(max_sample_size: max_sample_size)
      @heartbeat_history
        .add(first_heartbeat_estimate_ms - @std_deviation_ms)
        .add(first_heartbeat_estimate_ms + @std_deviation_ms)
    end

    def phi_at(timestamp_ms)
      last_timestamp_ms = @last_timestamp_ms
      return 0.0 if last_timestamp_ms.nil?

      timestamp_diff_ms = (timestamp_ms - last_timestamp_ms)
      mean_ms = (@heartbeat_history.mean + @acceptable_heartbeat_pause_ms)
      std_deviation_ms = ensure_valid_std_deviation(@heartbeat_history.std_deviation)

      y = (timestamp_diff_ms - mean_ms) / std_deviation_ms
      e = Math.exp(-y * (1.5976 + 0.070566 * y * y))

      if timestamp_diff_ms > mean_ms
        -Math.log10(e / (1.0 + e))
      else
        -Math.log10(1.0 - 1.0 / (1.0 + e))
      end
    end

    def phi
      phi_at(current_time_in_ms)
    end

    def available_at?(timestamp_ms)
      phi_at(timestamp_ms) < @threshold
    end

    def available?
      phi_at(current_time_in_ms) < @threshold
    end

    def heartbeat_at(timestamp_ms)
      last_timestamp_ms = @last_timestamp_ms
      @last_timestamp_ms = timestamp_ms
      return true if last_timestamp_ms.nil?

      interval = (timestamp_ms - last_timestamp_ms)
      if available_at?(timestamp_ms)
        @heartbeat_history.add(interval)
      end

      true
    end

    def heartbeat
      heartbeat_at(current_time_in_ms)
    end

    private

    def ensure_valid_std_deviation(std_deviation_ms)
      if std_deviation_ms > @min_std_deviation_ms
        std_deviation_ms
      else
        @min_std_deviation_ms
      end
    end

    def current_time_in_ms
      (Time.now.to_f * 1000).to_i
    end
  end
end
