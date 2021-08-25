# frozen_string_literal: true

require_relative '../../share/user'

RSpec.describe BrightSerializer::Serializer do
  let(:users) { Array.new(2).map { User.new } }

  describe 'sideloaders' do
    let(:serializer_class) do
      Class.new do
        include BrightSerializer::Serializer
        attributes :first_name do |object, _params, sideloaders|
          sideloaders.upcase_first_name[object.id]
        end

        sideload :upcase_first_name do |objects|
          objects.each_with_object({}) { |object, result| result[object.id] = object.first_name.upcase }
        end
      end
    end

    let(:instance) { serializer_class.new(users) }

    let(:result) do
      users.map { |user| { first_name: user.first_name.upcase } }
    end

    it 'serialize params' do
      expect(instance.to_hash).to eq(result)
    end

    context 'with params' do
      let(:serializer_class) do
        Class.new do
          include BrightSerializer::Serializer
          attributes :first_name do |object, _params, sideloaders|
            sideloaders.upcase_first_name[object.id]
          end

          sideload :upcase_first_name do |objects, params|
            objects.each_with_object({}) do |object, result|
              result[object.id] = "#{params[:prefix]} #{object.first_name.upcase}"
            end
          end
        end
      end

      let(:instance) { serializer_class.new(users, params: { prefix: 'Hi,' }) }

      let(:result) do
        users.map { |user| { first_name: "Hi, #{user.first_name.upcase}" } }
      end

      it 'serialize params' do
        expect(instance.to_hash).to eq(result)
      end
    end
  end
end
