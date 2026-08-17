[
  [ "Mainstage", 140, "Primary public performance space" ],
  [ "Black Box", 60, "Flexible rehearsal, workshop, and small event space" ],
  [ "Lobby", 75, "Reception and party area" ],
  [ "Classroom", 30, "Classes, workshops, and meetings" ]
].each do |name, capacity, description|
  Space.find_or_create_by!(name: name) do |space|
    space.capacity = capacity
    space.description = description
  end
end

mashup = Patron.find_or_create_by!(name: "Mashup") do |patron|
  patron.patron_type = :mashup
  patron.status = :active
  patron.email = "bookings@example.org"
end

if mashup.contacts.empty?
  mashup.contacts.create!(
    first_name: "Booking",
    last_name: "Desk",
    title: "Internal placeholder",
    email: "bookings@example.org",
    primary_contact: true
  )
end
