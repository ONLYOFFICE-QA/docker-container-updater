# frozen_string_literal: true

require_relative 'lib/docker_container_update'
DockerContainerUpdater::Updater.new.monitor_version
