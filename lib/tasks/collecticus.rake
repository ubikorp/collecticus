# =============================================================================
# Rake tasks for generating sample data in the development database.
# =============================================================================

namespace :collecticus do
  namespace :releases do
    desc "Refresh Comics Release Schedule Data"
    task :update => [:environment] do |t|
      require 'lib/zap_updater.rb'
      ZapUpdater.update
    end
  end
  
  namespace :news do
    desc "Refresh Remote News Feeds"
    task :update => [:environment] do |t|
      require 'feed_tools'
      
      FeedSource.find(:all).each do |source|
        result = FeedTools::Feed.open(source.url)
        result.items.each do |item|
          unless source.feed_articles.find(:first, :conditions => ["link = ?", item.link])
            new_article = source.feed_articles.build({
              :title => item.title,
              :link => item.link,
              :published_at => item.published || item.time,
              :author => item.author,
              :content => item.content
            })
            if new_article.save
              puts("Saved new article @ #{new_article.link}")
            else
              puts("Error saving article @ #{new_article.link}")
              puts(new_article.errors.full_messages)
            end
          end
        end
      end
    end
  end
  namespace :thumbnails do
    desc "Regenerate missing thumbnails"
    task :regenerate => [:environment] do |t|
      done = []
      Book.find(:all, :order => "created_at DESC").select { |p| p.cover_image && p.cover_image.thumbnails.size <= 1 }.each do |p|
        next if done.include?(p)
        puts("Regenerating thumbnail for #{p.name}")
        temp_file = p.cover_image.create_temp_file
        p.cover_image.attachment_options[:thumbnails].each { |suffix, size|
          p.cover_image.create_or_update_thumbnail(temp_file, suffix, *size)
        }
        done << p
        sleep(2)
      end
    end
  end
end
