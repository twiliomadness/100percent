xml.instruct! :xml, :version => "1.0"
xml.Response do
  xml.Say 'Please hold while we connect you with a voter needing help.', :voice => 'woman'       
  xml.Dial do
    xml.Conference @conference.id
  end
end