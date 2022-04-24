# frozen_string_literal: true

module PhiAccrual
  module Atomic
    class Fixnum
      def initialize(value: 0)
        @mutex = Mutex.new
        synchronize { @value = value }
      end

      def value
        synchronize { @value }
      end

      def value=(value)
        synchronize { @value = value }
      end

      def add(x)
        synchronize { @value = @value + x }
      end

      def increment(delta = 1)
        synchronize { @value += delta.to_i }
      end

      def decrement(delta = 1)
        synchronize { @value -= delta.to_i }
      end

      protected

      def synchronize
        @mutex.synchronize { yield }
      end
    end
  end
end
