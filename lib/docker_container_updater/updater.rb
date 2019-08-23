# frozen_string_literal: true

require 'open-uri'
require 'json'

module DockerContainerUpdater
  # Class for updating DocumentServer
  class Updater
    def initialize
      @image_name = 'onlyoffice/4testing-documentserver-ie'
      @container_name = '4testing-documentserver-ie'
      @hub_catcher_url = 'http://qa-services.teamlab.info:8088/'
    end

    # @return [Integer] Latest pushed data
    def latest_version
      repo_data = open(@hub_catcher_url).read
      JSON.parse(repo_data)['push_data']['pushed_at']
    end

    def cleanup_image
      p 'Cleaning up images'
      `docker stop #{@container_name}`
      `docker rm #{@container_name}`
      `docker rmi #{@image_name}`
    end

    def start_container
      `docker run -itd -p 80:80 --name #{@container_name} -v /opt/onlyoffice/Data:/var/www/onlyoffice/Data #{@image_name}`
      p 'Sleeping for wait for container to start'
      sleep 30
      `docker exec #{@container_name} sudo supervisorctl start ds:example`
      p 'Sleeping for wait for font generating'
      sleep 60
    end

    def run_tests
      `cd ~/RubymineProjects/SharedFunctional; git reset --hard; git pull --prune`
      `cd ~/RubymineProjects/OnlineDocuments; git reset --hard; git checkout develop; git pull --prune`
      `cd ~/RubymineProjects/OnlineDocuments && bundle update`
      system("cd ~/RubymineProjects/OnlineDocuments && SPEC_SERVER_IP=#{test_example_url} rake generate_reference_images && SPEC_SERVER_IP=#{test_example_url} rake editors_smoke")
    end

    def update_container
      cleanup_image
      start_container
      @installed_version = latest_version
    end

    def monitor_version
      loop do
        if @installed_version == latest_version
          p "Docker image was not updated. #{current_version_info}"
        else
          p "Docker image was updated. #{current_version_info}"
          update_container
          run_tests
        end
        sleep 60
      end
    end

    private

    # @return [String] external ip
    def my_external_ip
      open('http://ipinfo.io/ip').read.chop
    end

    # @return [String] text example url
    def test_example_url
      "http://#{my_external_ip}"
    end

    # @return [String] current installed version and latest version from hub
    def current_version_info
      "Installed 'pushed_at': #{@installed_version}. "\
      "Latest 'pushed_at': #{latest_version}"
    end
  end
end
