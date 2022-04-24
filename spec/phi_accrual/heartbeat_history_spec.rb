# frozen_string_literal: true

require "spec_helper"

RSpec.describe PhiAccrual::HeartbeatHistory do
  context "#initialize" do
    describe "when the max_sample_size argument is invalid" do
      it "raises an ArgumentError" do
        expect { described_class.new(max_sample_size: 0) }
          .to raise_error(ArgumentError, "max_sample_size must be >= 1, got 0")
      end
    end
  end
end
