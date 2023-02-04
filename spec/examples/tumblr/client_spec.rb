require 'spec_helper'

describe Tumblr::Client do
  context 'when using the generic copy' do
    let(:key) { 'thekey' }

    before do
      Tumblr.configure do |c|
        c.consumer_key = key
      end
    end

    it 'gives new clients those credentials' do
      client = described_class.new
      expect(client.credentials[:consumer_key]).to eq(key)
    end

    it 'has its own credentials' do
      expect(Tumblr.credentials[:consumer_key]).to eq(key)
    end

    it 'is able to make a new client (using these credentials)' do
      expect(Tumblr.new).to be_a(described_class)
      expect(Tumblr.new.credentials[:consumer_key]).to eq(key)
    end
  end

  context 'when using custom copies of the client' do
    let!(:client1) { described_class.new(consumer_key: 'key1') }
    let!(:client2) { described_class.new(consumer_key: 'key2') }

    it 'keeps them separate' do
      expect([
        client1.credentials[:consumer_key],
        client2.credentials[:consumer_key]
      ].uniq.count).to eq(2)
    end
  end

  describe 'api_scheme' do
    it 'defaults to https' do
      expect(described_class.new.api_scheme).to eq('https')
    end

    it 'can be set by the initializer' do
      client = described_class.new(api_scheme: 'http')
      expect(client.api_scheme).to eq('http')
    end

    it 'can be set globally' do
      Tumblr.configure do |c|
        c.api_scheme = 'http'
      end
      expect(described_class.new.api_scheme).to eq('http')
    end
  end
end
