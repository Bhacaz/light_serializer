# frozen_string_literal: true

require 'rspec'

RSpec.describe BrightSerializer::Sideloader do
  let(:instance) { described_class.new(loaders, nil) }
  let(:loaders) do
    { my_sideloader: proc { 'hello world' } }
  end

  describe '.method_missing' do
    it 'call the proc base on the method and key' do
      expect(instance.my_sideloader).to eq('hello world')
    end

    it 'call the proc once and used saved values in @loaded' do
      expect(instance.instance_variable_get(:@loaders)).to(
        receive(:[]).with(:my_sideloader).once.and_call_original
      )
      expect(instance.instance_variable_get(:@loaded)).to(
        receive(:[]).with(:my_sideloader).twice.and_call_original
      )
      expect(instance.my_sideloader).to eq('hello world')
      expect(instance.my_sideloader).to eq('hello world')
    end

    describe 'block pass objects' do
      let(:instance) { described_class.new(loaders, 'hello world') }
      let(:loaders) do
        { my_sideloader: proc { |object| object.upcase } }
      end

      it 'use objects in block' do
        expect(instance.my_sideloader).to eq('hello world'.upcase)
      end
    end
  end

  describe '.respond_to_missing?' do
    it 'check if the @loaders hash have key' do
      expect(instance).to respond_to(:my_sideloader)
      expect(instance).not_to respond_to(:somehting)
    end
  end
end
