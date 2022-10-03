# frozen_string_literal: true

RSpec.describe Eien::LocalConfig do
  let(:config) do
    Eien::LocalConfig.new
  end

  let(:config_dir) do
    File.join(Dir.pwd, ".eien")
  end

  let(:config_path) do
    File.join(config_dir, "config")
  end

  context "#load!" do
    subject do
      config.tap(&:load!)
    end

    context "config file exists" do
      it "should load config from file" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(config_dir)
          File.write(config_path, "---\ncontext: cntxt\napp: myapp")

          expect(subject.context).to eq "cntxt"
          expect(subject.app).to eq "myapp"
        end
      end
    end

    context "config file does not exist" do
      it "should load empty config" do
        FakeFS.with_fresh do
          expect(subject.context).to be_nil
          expect(subject.app).to be_nil
        end
      end
    end
  end

  context "#save!" do
    subject do
      config.tap(&:save!)
    end

    context "config file exists" do
      it "should save config to file" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(config_dir)
          File.write(config_path, "---\ncontext: cntxt\napp: myapp")

          config.load!

          config.context = "othercntxt"
          config.app = "otherapp"

          subject

          config_data = YAML.load(File.read(config_path))
          expect(config_data).to include("context" => "othercntxt", "app" => "otherapp")
        end
      end
    end

    context "config file does not exist" do
      it "should create new config file" do
        FakeFS.with_fresh do
          config.context = "cntxt"
          config.app = "myapp"

          expect(File.exist?(config_path)).to eq false

          subject

          expect(File.exist?(config_path)).to eq true

          config_data = YAML.load(File.read(config_path))
          expect(config_data).to include("context" => "cntxt", "app" => "myapp")
        end
      end
    end
  end
end
