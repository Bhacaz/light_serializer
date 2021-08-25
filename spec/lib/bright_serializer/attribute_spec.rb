# frozen_string_literal: true

require_relative '../../share/user'

RSpec.describe BrightSerializer::Attribute do
  let(:object_to_serialize) { { first_name: Faker::Name.first_name, is_admin: false } }

  describe '#serialize' do
    context 'when object is an hash' do
      shared_examples 'serializing_hash' do
        it 'return the value' do
          object_to_serialize.each_key do |key|
            instance = described_class.new(key.to_sym, nil, nil)
            expect(instance.serialize(object_to_serialize, {}, nil)).to eq object_to_serialize[key]
          end
        end
      end

      context 'when keys are symbol' do
        it_behaves_like 'serializing_hash'
      end

      context 'when keys are string' do
        let(:object_to_serialize) { { 'first_name' => Faker::Name.first_name, 'is_admin' => false } }

        it_behaves_like 'serializing_hash'
      end
    end

    context 'when object is an object' do
      let(:object_to_serialize) do
        User.new.tap { |user| allow(user).to receive(:is_admin).and_return(false) }
      end

      it 'return the value' do
        %i[first_name last_name is_admin].each do |attribute|
          instance = described_class.new(attribute, nil, nil)
          expect(instance.serialize(object_to_serialize, {}, nil)).to eq object_to_serialize.send(attribute)
        end
      end
    end
  end
end
