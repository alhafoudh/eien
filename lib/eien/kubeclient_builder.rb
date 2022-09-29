# frozen_string_literal: true

require "krane"

module Eien
  class KubeclientBuilder < Krane::KubeclientBuilder
    EIEN_ENDPOINT_PATH = "eien.freevision.sk"

    def build_eien_kubeclient(context)
      build_kubeclient(
        api_version: "v1",
        context: context,
        endpoint_path: "/apis/#{EIEN_ENDPOINT_PATH}"
      )
    end
  end
end
