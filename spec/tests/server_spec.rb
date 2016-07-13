require "serverspec"
require "docker"

set :backend, :docker

describe "Dockerfile" do
  before(:all) do
    @container = Docker::Container.create(
      'Image' => ENV['DOCKER_IMAGE_NAME'] + ':' + ENV['DOCKER_IMAGE_TAG'],
      'Env' => [
        'ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster-1',
        'ETCD_NAME=etcd-server',
        'ETCD_ADVERTISE_CLIENT_URLS=http://127.0.0.1:2379'
      ]
    )
    @container.start

    set :docker_container, @container.id
  end

  describe command('etcdctl member list') do
    its(:stdout) { should match "name=etcd-server peerURLs=http://localhost:2380 clientURLs=http://127.0.0.1:2379 isLeader=true" }
  end

  describe command('etcdctl cluster-health') do
    its(:stdout) { should match "cluster is healthy" }
  end

  describe command('curl -I -X GET http://localhost:2379/version') do
    its(:stdout) { should match "HTTP/1.1 200 OK" }
  end

  describe command('etcdctl set testkey testvalue') do
    its(:exit_status) { should eq 0 }
  end

  describe command('etcdctl get testkey') do
    its(:stdout) { should eq "testvalue\n" }
  end

  after(:all) do
    if !@container.nil?
      @container.delete('force' => true)
    end
  end
end
