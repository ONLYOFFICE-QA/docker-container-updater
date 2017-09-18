require 'open-uri'
require 'json'

module DockerContainerUpdater
  class Updater
    def initialize
      @image_name = 'onlyoffice/4testing-documentserver-integration'
      @container_name = '4testing-documentserver-integration'
      @hub_catcher_url = 'http://67.205.182.89:8088/'
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
      `docker exec #{@container_name} sudo supervisorctl start onlyoffice-documentserver:example`
      p 'Sleeping for wait for font generating'
      sleep 60
    end

    def run_tests
      `cd ~/RubymineProjects/SharedFunctional; git reset --hard; git pull --prune`
      `cd ~/RubymineProjects/OnlineDocuments; git reset --hard; git checkout develop; git pull --prune`
      `cd ~/RubymineProjects/OnlineDocuments && bundle update`
      system("cd ~/RubymineProjects/OnlineDocuments && SPEC_SERVER_IP=#{my_external_ip} rake editors_smoke")
    end

    def update_container
      cleanup_image
      start_container
      @installed_version = latest_version
    end

    def monitor_version
      loop do
        if @installed_version == latest_version
          p 'Docker image was not updated'
        else
          p 'Docker image was updated'
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
  end
end
