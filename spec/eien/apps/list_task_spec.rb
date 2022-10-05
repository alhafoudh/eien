# frozen_string_literal: true

RSpec.describe Eien::Apps::ListTask do
  let(:context) do
    "cntxt"
  end

  subject do
    Eien::Apps::ListTask.new(context).run!
  end

  before(:each) do
    allow($stdout).to receive(:puts)
  end

  it "should list apps" do
    kubeclient = double
    expect_any_instance_of(Eien::KubeclientBuilder).to receive(:build_eien_kubeclient).and_return(kubeclient)
    expect(kubeclient).to receive(:get_apps).and_return([
      Kubeclient::Resource.new(
        metadata: {
          name: "app1",
          creationTimestamp: Time.now.to_s,
        },
        spec: {
          namespace: "app1_namespace",
        },
      ),
      Kubeclient::Resource.new(
        metadata: {
          name: "app2",
          creationTimestamp: Time.now.to_s,
        },
        spec: {
          namespace: "app2_namespace",
        },
      ),
    ])

    expect(TTY::Table).to receive(:new).with([
      "NAME", "NAMESPACE", "AGE",
    ], [
      include("app1", "app1_namespace"),
      include("app2", "app2_namespace"),
    ]).and_call_original

    subject
  end
end
