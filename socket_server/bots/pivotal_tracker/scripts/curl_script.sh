curl -i -X POST -d '<?xml version="1.0" encoding="UTF-8"?> <activity> <id type="integer">121552143</id> <version type="integer">1110</version> <event_type>story_update</event_type> <occurred_at type="datetime">2011/10/08 17:51:30 UTC</occurred_at> <author>Don Petersen</author> <project_id type="integer">365557</project_id> <description>Don Petersen delivered "User can associate a tracker story ID with a tag"</description> <stories type="array"> <story> <id type="integer">19434183</id> <url>http://www.pivotaltracker.com/services/v3/projects/365557/stories/19434183</url> <current_state>delivered</current_state> </story> </stories> </activity>' http://localhost:9292/bots/pivotal_tracker/activity_hook_target/
