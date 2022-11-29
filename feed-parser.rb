require 'nokogiri'
require 'json'

require './external-service'

class FeedParser
  BATCH_LIMIT = 5 * 1_048_576.0

  def initialize(file)
    @doc = File.open(file) { |f| Nokogiri::XML(f) }
    @externalService = ExternalService.new
    @batch = nil
    @batchSize = nil

    initBatch()
  end

  def call
    @doc.xpath('//item').each do |item|
      product = {
        id: item.element_children.at('g|id').text,
        title: item.element_children.search('title').text,
        description: item.element_children.search('description').text
      }

      @batch.append(product)

      size = product.to_json.size

      @batchSize += size

      if @batchSize >= BATCH_LIMIT then
        callExternal()
        initBatch()
      end
    end

    callExternal()
  end

  private

  def callExternal()
    if @batch.length() > 0 then
      @externalService.call(@batch.to_json)
    end
  end

  def initBatch()
    @batch = []
    @batchSize = 0
  end
end
