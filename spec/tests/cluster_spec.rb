require 'serverspec'
require 'docker'

set :backend, :docker

describe 'Dockerfile' do
  before(:all) do
    @server1 = Docker::Container.create(
      'name' => 'etcd-server-1',
      'Image' => ENV['DOCKER_IMAGE_NAME'] + ':' + ENV['DOCKER_IMAGE_TAG'],
      'Env' => [
        'ETCD_NAME=etcd-server-1',
        'ETCD_ADVERTISE_CLIENT_URLS=http://127.0.0.1:12379',
        'ETCD_LISTEN_PEER_URLS=http://127.0.0.1:12380',
        'ETCD_LISTEN_CLIENT_URLS=http://127.0.0.1:12379',
        'ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster-1',
        'ETCD_INITIAL_ADVERTISE_PEER_URLS=http://127.0.0.1:12380',
        'ETCD_INITIAL_CLUSTER=etcd-server-1=http://127.0.0.1:12380,etcd-server-2=http://127.0.0.1:22380,etcd-server-3=http://127.0.0.1:32380'
      ],
      'ExposedPorts'=> {
        '12379/tcp'=> {},
        '12380/tcp'=> {}
      },
      'HostConfig' => {
        'NetworkMode' => 'host'
      }
    )
    @server1.start

    @server2 = Docker::Container.create(
      'name' => 'etcd-server-2',
      'Image' => ENV['DOCKER_IMAGE_NAME'] + ':' + ENV['DOCKER_IMAGE_TAG'],
      'Env' => [
        'ETCD_NAME=etcd-server-2',
        'ETCD_ADVERTISE_CLIENT_URLS=http://127.0.0.1:22379',
        'ETCD_LISTEN_PEER_URLS=http://127.0.0.1:22380',
        'ETCD_LISTEN_CLIENT_URLS=http://127.0.0.1:22379',
        'ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster-1',
        'ETCD_INITIAL_ADVERTISE_PEER_URLS=http://127.0.0.1:22380',
        'ETCD_INITIAL_CLUSTER=etcd-server-1=http://127.0.0.1:12380,etcd-server-2=http://127.0.0.1:22380,etcd-server-3=http://127.0.0.1:32380'
      ],
      'ExposedPorts'=> {
        '22379/tcp'=> {},
        '22380/tcp'=> {}
      },
      'HostConfig' => {
        'NetworkMode' => 'host'
      }
    )
    @server2.start

    @server3 = Docker::Container.create(
      'name' => 'etcd-server-3',
      'Image' => ENV['DOCKER_IMAGE_NAME'] + ':' + ENV['DOCKER_IMAGE_TAG'],
      'Env' => [
        'ETCD_NAME=etcd-server-3',
        'ETCD_ADVERTISE_CLIENT_URLS=http://127.0.0.1:32379',
        'ETCD_LISTEN_PEER_URLS=http://127.0.0.1:32380',
        'ETCD_LISTEN_CLIENT_URLS=http://127.0.0.1:32379',
        'ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster-1',
        'ETCD_INITIAL_ADVERTISE_PEER_URLS=http://127.0.0.1:32380',
        'ETCD_INITIAL_CLUSTER=etcd-server-1=http://127.0.0.1:12380,etcd-server-2=http://127.0.0.1:22380,etcd-server-3=http://127.0.0.1:32380'
      ],
      'ExposedPorts'=> {
        '32379/tcp'=> {},
        '32380/tcp'=> {}
      },
      'HostConfig' => {
        'NetworkMode' => 'host'
      }
    )
    @server3.start

    sleep(1)

    set :docker_container, @server1.id
  end

  describe command('etcdctl --endpoints=http://127.0.0.1:12379 member list') do
    its(:stdout) { should match 'name=etcd-server-1 peerURLs=http://127.0.0.1:12380 clientURLs=http://127.0.0.1:12379' }
    its(:stdout) { should match 'name=etcd-server-2 peerURLs=http://127.0.0.1:22380 clientURLs=http://127.0.0.1:22379' }
    its(:stdout) { should match 'name=etcd-server-3 peerURLs=http://127.0.0.1:32380 clientURLs=http://127.0.0.1:32379' }
    its(:stdout) { should match 'isLeader=true' }
  end

  describe command('etcdctl --endpoints=http://127.0.0.1:12379 cluster-health') do
    its(:stdout) { should match 'cluster is healthy' }
  end

  describe command('etcdctl --endpoints=http://127.0.0.1:12379 set testkey testvalue') do
    its(:exit_status) { should eq 0 }
  end

  describe command('etcdctl --endpoints=http://127.0.0.1:12379 get testkey') do
    its(:stdout) { should eq "testvalue\n" }
  end

  after(:all) do
    if !@server1.nil?
      @server1.delete('force' => true)
    end
    if !@server2.nil?
      @server2.delete('force' => true)
    end
    if !@server3.nil?
      @server3.delete('force' => true)
    end
  end
end
