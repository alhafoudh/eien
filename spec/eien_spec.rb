# frozen_string_literal: true

RSpec.describe Eien do
  it "::VERSION" do
    expect(Eien::VERSION).not_to be nil
  end

  it ".root" do
    expect(Eien.root).to eq File.expand_path('.')
  end

  it ".crd_dir" do
    expect(Eien.crd_dir).to eq File.expand_path('./crds')
  end

  it ".prepare_krane_options" do
    krane_options = {
      option1: {
        default: 1
      },
      option2: {
        default: 2
      },
    }
    expect(Eien.prepare_krane_options(krane_options)).to eq({
      "option1" => 1,
      "option2" => 2,
    })
  end

  context ".context_or_default" do
    it "should return context if supplied" do
      expect(Eien.context_or_default("foo")).to eq "foo"
    end

    it "should fallback to default if context is not supplied" do
      expect_any_instance_of(Eien::LocalConfig).to receive(:context).and_return("default")
      expect(Eien.context_or_default(nil)).to eq "default"
    end
  end

  context ".app_or_default" do
    it "should return app if supplied" do
      expect(Eien.app_or_default("foo")).to eq "foo"
    end

    it "should fallback to default if app is not supplied" do
      expect_any_instance_of(Eien::LocalConfig).to receive(:app).and_return("default")
      expect(Eien.app_or_default(nil)).to eq "default"
    end
  end

  it ".build_eien_kubeclient" do
    context = double
    kubeclient_stub = instance_double(Kubeclient::Client)
    expect_any_instance_of(Krane::KubeclientBuilder).to receive(:build_kubeclient).with(api_version: "v1",
      context: context,
      endpoint_path: "/apis/eien.freevision.sk",).and_return(kubeclient_stub)

    expect(Eien.build_eien_kubeclient(context)).to eq kubeclient_stub
  end

  context ".app_from_name" do
    let(:app_name) do
      "myapp"
    end

    let(:the_app) do
      instance_double(Kubeclient::Resource)
    end

    def cntxt
      "cntxt"
    end

    let(:kubeclient) do
      double(Kubeclient::Client)
    end

    before(:each) do
      expect(Eien).to receive(:build_eien_kubeclient).with(cntxt).and_return(kubeclient)
    end

    it "should return app resource when it exists" do
      expect(kubeclient).to receive(:get_app).with(app_name).and_return(the_app)

      expect(Eien.app_from_name(cntxt, app_name)).to eq the_app
    end

    it "should raise exception if app does not exist" do
      expect(kubeclient).to receive(:get_app).with(app_name).and_raise(Kubeclient::ResourceNotFoundError.new(404,
double, double))

      expect do
        Eien.app_from_name(cntxt, app_name)
      end.to raise_error(Eien::Errors::UserInputError, "App myapp does not exist.")
    end
  end

  it ".secret_name" do
    expect(Eien.secret_name("foo")).to eq "foo-secret"
  end

  it ".config_map_name" do
    expect(Eien.config_map_name("foo")).to eq "foo-config"
  end
end
