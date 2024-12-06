# frozen_string_literal: true

require 'logger'
require 'open-uri'
require 'json'

# Default namespace for app
module DockerContainerUpdater
  # Class for updating DocumentServer
  class Updater
    def initialize
      @image_name = 'onlyoffice/4testing-documentserver-ee'
      @container_name = '4testing-documentserver-ee'
      @docker_hub_latest_url = 'https://hub.docker.com/v2' \
                               "/repositories/#{@image_name}" \
                               '/tags/latest'
      @monitor_version_timeout = 5 * 60
      @logger = Logger.new($stdout)
    end

    # @return [Hash] information about `latest` tag
    def latest_info
      repo_data = URI.parse(@docker_hub_latest_url).open.read
      JSON.parse(repo_data)
    end

    # @return [Integer] Latest pushed data
    def latest_version
      latest_info['last_updated']
    end

    # @return [True, False] is latest build have amd64 arch
    def latest_has_amd64?
      architectures = latest_info['images'].map { |image| image['architecture'] }
      architectures.include?('amd64')
    end

    # Remove all old images
    # @return [nil]
    def cleanup_image
      @logger.info('Cleaning up images')
      `docker stop #{@container_name}`
      `docker rm #{@container_name}`
      `docker rmi #{@image_name}`
      `docker volume prune -f`
      @logger.info('Finished cleaning up old images')
    end

    # Start configured container
    # @return [nil]
    def start_container
      `#{docker_run_command}`
      @logger.info('Sleeping for wait for container to start')
      sleep 120
      `#{enable_test_example_command}`
      enable_exmaple_autostart
      @logger.info('Sleeping for wait for font generating')
      sleep 60
    end

    # Run test
    # @return [nil]
    def run_tests
      `cd ~/RubymineProjects/OnlineDocuments; \
       git pull --prune`
      `cd ~/RubymineProjects/OnlineDocuments && bundle install`
      system('cd ~/RubymineProjects/OnlineDocuments && ' \
             "SPEC_SERVER_IP=#{test_example_url} " \
             'rake generate_reference_images && ' \
             "SPEC_SERVER_IP=#{test_example_url} rake editors_smoke")
    end

    # Update current run container
    # @return [nil]
    def update_container
      cleanup_image
      start_container
      @installed_version = latest_version
    end

    # Background method to check if new version of
    # container is released
    # @return [nil]
    def monitor_version
      loop do
        check_version_update
        sleep(@monitor_version_timeout)
      end
    end

    private

    # Check if there is a newer version of docker container
    def check_version_update
      if @installed_version == latest_version
        @logger.info("Docker image was not updated. #{current_version_info}")
      elsif latest_has_amd64?
        @logger.info("Docker image was updated. #{current_version_info}")
        update_container
        run_tests
      else
        @logger.warn('Latest Docker image was updated, but do not have amd64 version')
      end
    end

    # @return [String] external ip
    def my_external_ip
      URI.parse('http://ipinfo.io/ip').open.read.chomp
    end

    # @return [String] get domain name by external ip
    def my_domain_name
      nslookup_result = `nslookup #{my_external_ip}`
      line = nslookup_result.split(' = ')[1]
      line.split("\n").first.chop
    rescue StandartError => e
      raise "Cannot handle nskookup result: `#{nslookup_result}` with error: `#{e}`"
    end

    # @return [String] text example url
    def test_example_url
      "https://#{my_domain_name}"
    end

    # @return [String] current installed version and latest version from hub
    def current_version_info
      "Installed 'pushed_at': #{@installed_version}. " \
        "Latest 'pushed_at': #{latest_version}"
    end

    # Enable autostart of DocumentServer test example
    # @return [Void]
    def enable_exmaple_autostart
      `docker exec #{@container_name} \
       sed 's,autostart=false,autostart=true,' \
       -i /etc/supervisor/conf.d/ds-example.conf`
    end

    # @return [String] command to enable test example
    def enable_test_example_command
      "docker exec #{@container_name} supervisorctl start all"
    end

    # Docker run command for starting continer
    # @return [String] docker run command
    def docker_run_command
      'docker run -itd ' \
        '-p 80:80 ' \
        '-p 443:443 ' \
        "--name #{@container_name} " \
        '-e JWT_ENABLED=false ' \
        '-e WOPI_ENABLED=true ' \
        '-v /opt/onlyoffice/Data:/var/www/onlyoffice/Data ' \
        "#{@image_name}"
    end
  end
end
