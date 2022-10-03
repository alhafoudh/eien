# frozen_string_literal: true

RSpec.describe Eien::InitTask do
  let(:context) do
    "cntxt"
  end

  subject do
    Eien::InitTask.new(context).run!
  end

  it "should deploy CRS's with krane" do
    expect(Krane::CLI::GlobalDeployCommand).to receive(:from_options) do |c, arg|
      expect(c).to eq context
      expect(arg).to include(
        selector: "owner=eien.freevision.sk",
      )
      expect(arg[:filenames].first).to match(%r{/crds$})
    end.and_return(double)

    expect_any_instance_of(Eien::LocalConfig).to receive(:save!).and_return(double)

    subject
  end

  it "should set context in config after successfull init" do
    FakeFS.with_fresh do
      expect(Eien.config.context).to be_nil

      expect(Krane::CLI::GlobalDeployCommand).to receive(:from_options).and_return(double)
      expect_any_instance_of(Eien::LocalConfig).to receive(:save!).and_return(double)

      subject

      expect(Eien.config.context).to eq context
    end
  end
end
