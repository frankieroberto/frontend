# encoding: utf-8
require 'integration_test_helper'

class CompletedTransactionTest < ActionDispatch::IntegrationTest
  setup do
    @payload = {
      base_path: "/done/no-promotion",
      schema_name: "completed_transaction",
      document_type: 'completed_transaction',
      external_related_links: []
    }
  end

  context "a completed transaction edition" do
    should "show no promotion when there is no promotion choice" do
      content_store_has_item('/done/no-promotion', @payload)
      visit "/done/no-promotion"

      assert_equal 200, page.status_code
      within '.content-block' do
        assert page.has_no_selector?('#organ-donor-registration-promotion')
        assert page.has_no_selector?('#register-to-vote-promotion')
      end
    end
  end

  context "legacy transaction finished pages' special cases" do
    should "not show the satisfaction survey for transaction-finished" do
      payload = @payload.merge(base_path: "/done/transaction-finished")

      content_store_has_item("/done/transaction-finished", payload)

      visit "/done/transaction-finished"

      assert_not page.has_css?("h2.satisfaction-survey-heading")
    end

    should "not show the satisfaction survey for driving-transaction-finished" do
      payload = @payload.merge(base_path: "/done/driving-transaction-finished")

      content_store_has_item("/done/driving-transaction-finished", payload)

      visit "/done/driving-transaction-finished"

      assert_not page.has_css?("h2.satisfaction-survey-heading")
    end
  end

  context 'satisfaction surveys' do
    context 'for editions using the assisted digital survey' do
      setup do
        payload = @payload.merge(base_path: "/done/register-flood-risk-exemption")
        content_store_has_item("/done/register-flood-risk-exemption", payload)
        visit '/done/register-flood-risk-exemption'
      end

      should 'have a form that posts to the assisted-digital-survey endpoint' do
        assert page.has_text?('Help us improve this service')

        assert page.has_selector?("form[action='/contact/govuk/assisted-digital-survey-feedback']")

        within "form[action='/contact/govuk/assisted-digital-survey-feedback']" do
          within_fieldset "Did you receive any assistance to use this service today?" do
            assert page.has_field?("Yes", type: "radio")
            assert page.has_field?("No", type: "radio")
          end

          within_fieldset "What assistance did you receive?" do
            assert page.has_field?("Your comments", type: 'textarea')
          end

          within_fieldset "Who provided the assistance?" do
            assert page.has_field?("A friend or relative", type: 'radio')
            assert page.has_field?("A work colleague", type: 'radio')
            assert page.has_field?("A staff member of the responsible government department", type: 'radio')
            assert page.has_field?("Other (please specify)", type: 'radio')
            assert page.has_field?("Tell us who the other person was", type: 'text')
          end

          within_fieldset "How satisfied are you with the assistance received?" do
            assert page.has_field?("Very satisfied", type: 'radio')
            assert page.has_field?("Satisfied", type: 'radio')
            assert page.has_field?("Neither satisfied or dissatisfied", type: 'radio')
            assert page.has_field?("Dissatisfied", type: 'radio')
            assert page.has_field?("Very dissatisfied", type: 'radio')
          end

          within_fieldset "Is there any way the assistance received could be improved?" do
            assert page.has_field?("Your comments", type: 'textarea')
          end

          within_fieldset "Overall, how satisfied are you with the online service?" do
            assert page.has_field?("Very satisfied", type: 'radio')
            assert page.has_field?("Satisfied", type: 'radio')
            assert page.has_field?("Neither satisfied or dissatisfied", type: 'radio')
            assert page.has_field?("Dissatisfied", type: 'radio')
            assert page.has_field?("Very dissatisfied", type: 'radio')
          end

          within_fieldset "Do you have any ideas for how this service could be improved?" do
            assert page.has_field?("Your comments", type: 'textarea')
          end

          assert page.has_button?('Send feedback')
        end
      end
    end

    context 'for editions using the normal satisfaction survey' do
      setup do
        payload = @payload.merge(base_path: "/done/register-to-vote")
        content_store_has_item("/done/register-to-vote", payload)
        visit '/done/register-to-vote'
      end

      should 'have a form that posts to the service-feedback endpoint' do
        assert page.has_text?('Satisfaction survey')

        assert page.has_selector?("form[action='/contact/govuk/service-feedback']")

        within "form[action='/contact/govuk/service-feedback']" do
          within_fieldset "Overall, how did you feel about the service you received today?" do
            assert page.has_field?("Very satisfied", type: 'radio')
            assert page.has_field?("Satisfied", type: 'radio')
            assert page.has_field?("Neither satisfied or dissatisfied", type: 'radio')
            assert page.has_field?("Dissatisfied", type: 'radio')
            assert page.has_field?("Very dissatisfied", type: 'radio')
          end

          within_fieldset "How could we improve this service?" do
            assert page.has_field?("Your comments", type: 'textarea')
          end

          assert page.has_button?('Send feedback')
        end
      end
    end
  end
end
