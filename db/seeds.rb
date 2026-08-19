spaces = [ [ "Mainstage", 140, "Primary public performance space" ] ]

if Rails.env.development? || ENV["SEED_DEMO_DATA"] == "true"
  spaces.concat([
    [ "Black Box", 60, "Flexible rehearsal, workshop, and small event space" ],
    [ "Lobby", 75, "Reception and party area" ],
    [ "Classroom", 30, "Classes, workshops, and meetings" ]
  ])
end

spaces.each do |name, capacity, description|
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

if Rails.env.development? || ENV["SEED_DEMO_DATA"] == "true"
  demo_patrons = [
    {
      name: "River City Players",
      patron_type: :nonprofit,
      email: "booking@rivercityplayers.example",
      contact: [ "Jordan", "Lee", "Producer" ]
    },
    {
      name: "Detroit Arts Collective",
      patron_type: :partner,
      email: "programs@detroitarts.example",
      contact: [ "Morgan", "Davis", "Programs Director" ]
    },
    {
      name: "Bright Lights Events",
      patron_type: :for_profit,
      email: "events@brightlights.example",
      contact: [ "Taylor", "Brooks", "Event Manager" ]
    }
  ].map do |attributes|
    patron = Patron.find_or_create_by!(name: attributes[:name]) do |record|
      record.patron_type = attributes[:patron_type]
      record.status = :active
      record.email = attributes[:email]
    end

    if patron.contacts.empty?
      patron.contacts.create!(
        first_name: attributes[:contact][0],
        last_name: attributes[:contact][1],
        title: attributes[:contact][2],
        email: attributes[:email],
        primary_contact: true,
        billing_contact: true
      )
    end

    patron
  end

  river_city, arts_collective, bright_lights = demo_patrons
  first_monday = Date.current.next_occurring(:monday)

  performance = Booking.find_or_initialize_by(title: "Autumn Repertory", patron: river_city)
  performance.assign_attributes(
    primary_contact: river_city.contacts.first,
    booking_type: :performance_public,
    status: :confirmed,
    public_event: true,
    starts_on: first_monday + 14.days,
    ends_on: first_monday + 27.days,
    estimated_attendance: 120,
    contract_status: :signed,
    description: "Two-week repertory engagement on the Mainstage."
  )
  performance.save!

  if performance.booking_runs.empty?
    [ 18, 19, 25, 26 ].each do |day_offset|
      date = first_monday + day_offset.days
      starts_at = Time.zone.local(date.year, date.month, date.day, day_offset.in?([ 19, 26 ]) ? 14 : 19)
      performance.booking_runs.create!(space: Space.find_by!(name: "Mainstage"), starts_at: starts_at, ends_at: starts_at + 3.hours, status: :held)
    end
  end

  workshop = Booking.find_or_initialize_by(title: "Community Devising Workshop", patron: arts_collective)
  workshop.assign_attributes(
    primary_contact: arts_collective.contacts.first,
    booking_type: :class_workshop_public,
    status: :confirmed,
    public_event: true,
    starts_on: first_monday + 7.days,
    ends_on: first_monday + 11.days,
    estimated_attendance: 24,
    contract_status: :filed,
    description: "A five-day partner workshop."
  )
  workshop.save!

  if workshop.booking_runs.empty?
    (7..11).each do |day_offset|
      date = first_monday + day_offset.days
      starts_at = Time.zone.local(date.year, date.month, date.day, 10)
      workshop.booking_runs.create!(space: Space.find_by!(name: "Classroom"), starts_at: starts_at, ends_at: starts_at + 4.hours, status: :held)
    end
  end

  party_date = first_monday + 12.days
  party = Booking.find_or_initialize_by(title: "Company Anniversary Reception", patron: bright_lights)
  party.assign_attributes(
    primary_contact: bright_lights.contacts.first,
    booking_type: :party,
    status: :tentative,
    starts_on: party_date,
    ends_on: party_date,
    estimated_attendance: 65,
    contract_status: :sent,
    description: "Private reception in the lobby."
  )
  party.save!

  if party.booking_runs.empty?
    starts_at = Time.zone.local(party_date.year, party_date.month, party_date.day, 18)
    party.booking_runs.create!(space: Space.find_by!(name: "Lobby"), starts_at: starts_at, ends_at: starts_at + 5.hours, status: :planned)
  end
end
