class TransactionController < ApplicationController
  include Cacheable
  include Navigable
  include EducationNavigationABTestable

  before_action :set_content_item
  before_action :deny_framing

  def show
    @register_to_vote_slugs = %w(
      register-to-vote
      register-to-vote-crown-servants-british-council-employees
      register-to-vote-armed-forces
      cofrestru-i-bleidleisio
    )
  end

  def jobsearch
  end

private

  def set_content_item
    super(TransactionPresenter)
  end

  def deny_framing
    response.headers['X-Frame-Options'] = 'DENY'
  end
end
