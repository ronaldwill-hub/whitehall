require 'test_helper'

class FatalityNoticesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_inline_images_for :news_article
  should_show_change_notes :news_article

  test "shows published news article" do
    fatality_notice = create(:published_fatality_notice)
    get :show, id: fatality_notice.document
    assert_response :success
  end

  test "renders the news article summary from plain text" do
    fatality_notice = create(:published_fatality_notice, summary: 'plain text & so on')
    get :show, id: fatality_notice.document

    assert_select ".summary", text: "plain text &amp; so on"
  end

  test "renders the news article body using govspeak" do
    fatality_notice = create(:published_fatality_notice, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: fatality_notice.document
    end

    assert_select ".body", text: "body-in-html"
  end

  #test "shows when updated news article was first published and last updated" do
    #news_article = create(:published_news_article, published_at: 10.days.ago)

    #editor = create(:departmental_editor)
    #updated_news_article = news_article.create_draft(editor)
    #updated_news_article.change_note = "change-note"
    #updated_news_article.publish_as(editor, force: true)

    #get :show, id: updated_news_article.document

    #assert_select ".meta" do
      #assert_select ".published-at[title='#{news_article.first_published_at.iso8601}']"
      #assert_select ".published-at[title='#{updated_news_article.published_at.iso8601}']"
    #end
  #end

  #test "the format name is being set to news" do
    #news_article = create(:published_news_article)

    #get :show, id: news_article.document

    #assert_equal "news", response.headers["X-Slimmer-Format"]
  #end
end
