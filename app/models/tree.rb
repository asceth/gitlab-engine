class Tree
   include Linguist::BlobHelper
  attr_accessor :path, :tree, :project, :ref

  delegate :contents,
    :basename,
    :name,
    :data,
    :mime_type,
    :mode,
    :size,
    :text?,
    :colorize,
    :to => :tree

  def initialize(raw_tree, project, ref = nil, path = nil)
    @project, @ref, @path = project, ref, path,
    @tree = if path
              raw_tree / path
            else
              raw_tree
            end
  end

  def is_blob?
    tree.is_a?(Grit::Blob)
  end

  def empty?
    data.blank?
  end
end
