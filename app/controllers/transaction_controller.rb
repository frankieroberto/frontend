class TransactionController < ApplicationController
  include Cacheable
  include Navigable
  include EducationNavigationABTestable

  before_action :set_content_item
  before_action :deny_framing

  def show
  end

  def jobsearch
  end

  slimmer_template 'core_layout'

private

  def set_content_item
    super(TransactionPresenter)
  end

  def deny_framing
    response.headers['X-Frame-Options'] = 'DENY'
  end
end
