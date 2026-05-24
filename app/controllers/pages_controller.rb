class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "geocities"

  def home
    SiteCounter.increment!(:home_visits)
    @visitor_count = SiteCounter.count_for(:home_visits)
    @recent_entries = GuestbookEntry.recent.limit(3)
    @recent_items = ListItem.joins(:item).order(created_at: :desc).limit(5)
  end

  def about
  end

  def links
  end

  def apps
  end

  def guestbook
    @entries = GuestbookEntry.recent
    @entry = GuestbookEntry.new
  end

  def sign_guestbook
    # Simple honeypot check
    if params[:guestbook_entry][:website].present?
      return redirect_to guestbook_path, notice: "Thanks for signing my guestbook!!"
    end

    @entry = GuestbookEntry.new(guestbook_params)

    if @entry.save
      redirect_to guestbook_path, notice: "Thanks for signing my guestbook!!"
    else
      @entries = GuestbookEntry.recent
      render :guestbook, status: :unprocessable_entity
    end
  end

  private

  rate_limit to: 3, within: 1.minute, only: :sign_guestbook, with: -> { redirect_to guestbook_path, alert: "Slow down! You're signing the guestbook too fast." } unless Rails.env.test?

  def guestbook_params
    params.expect(guestbook_entry: [ :name, :message ])
  end
end
