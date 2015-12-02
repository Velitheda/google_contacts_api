describe 'Contacts API v3 fields' do
  before do
    @empty = GoogleContactsApi::Contact.new

    @partly_empty = GoogleContactsApi::Contact.new(
      'gd$name' => {},
      'gContact$relation' => []
    )

    @contact_v3 = GoogleContactsApi::Contact.new(
      'gd$name' => {
        'gd$givenName' => { '$t' => 'John' },
        'gd$familyName' => { '$t' => 'Doe' },
        'gd$fullName' => { '$t' => 'John Doe' }
      },
      'gContact$relation' => [ { '$t' => 'Jane', 'rel' => 'spouse' } ],
      'gd$structuredPostalAddress' => [
        {
          "rel" => "http://schemas.google.com/g/2005#work",
          'gd$country' => { '$t' => 'United States of America' },
          'gd$formattedAddress' => {
            '$t' => "2345 Long Dr. #232\nSomwhere\nIL\n12345\n" \
            "United States of America" },
          'gd$city' => { '$t' => 'Somwhere' },
          'gd$street' => { '$t' => '2345 Long Dr. #232' },
          'gd$region' => { '$t' => 'IL' },
          'gd$postcode' => { '$t' => '12345' }
        },
        {
          'rel' => 'http://schemas.google.com/g/2005#home',
          'gd$country' => { '$t' => 'United States of America' },
          'gd$formattedAddress' => { '$t' => "123 Far Ln.\nAnywhere\nMO\n" \
            "67891\nUnited States of America" },
          'gd$city' => { '$t' => 'Anywhere' },
          'gd$street' => { '$t' => '123 Far Ln.' },
          'gd$region' => { '$t' => 'MO' },
          'gd$postcode' => { '$t' => '67891' }
        }
      ],
      'gd$email' => [
        {
          'primary' => 'true',
          'rel' => 'http://schemas.google.com/g/2005#other',
          'address' => 'johnsmith@example.com'
        }
      ],
      'gd$phoneNumber' => [
        {
          'primary' => 'true',
          '$t' => '(123) 334-5158',
          'rel' => 'http://schemas.google.com/g/2005#mobile'
        }
      ]
    )
  end

  it 'should catch nil values for nested fields' do
    expect(@empty.nested_t_field_or_nil('gd$name', 'gd$givenName')).to be_nil
    expect(@partly_empty.nested_t_field_or_nil('gd$name', 'gd$givenName')).
      to be_nil
    expect(@contact_v3.nested_t_field_or_nil('gd$name', 'gd$givenName')).
      to eq('John')
  end

  it 'has given_name' do
    expect(@contact_v3).to receive(:nested_t_field_or_nil)
      .with('gd$name', 'gd$givenName').and_return('val')
    expect(@contact_v3.given_name).to eq('val')
  end

  it 'has family_name' do
    expect(@contact_v3).to receive(:nested_t_field_or_nil).with('gd$name',
      'gd$familyName').and_return('val')
    expect(@contact_v3.family_name).to eq('val')
  end

  it 'has full_name' do
    expect(@contact_v3).to receive(:nested_t_field_or_nil).with('gd$name',
      'gd$fullName').and_return('val')
    expect(@contact_v3.full_name).to eq('val')
  end

  it 'has relations' do
    expect(@empty.relations).to eq([])
    expect(@partly_empty.relations).to eq([])
    expect(@contact_v3.relations).to eq([
     { '$t' => 'Jane', 'rel' => 'spouse' }
    ])
  end
  it 'has spouse' do
    expect(@empty.spouse).to be_nil
    expect(@partly_empty.spouse).to be_nil
    expect(@contact_v3.spouse).to eq('Jane')
  end

  it 'has addresses' do
    expect(@empty.addresses).to eq([])

    formatted_addresses = [
      {
          :rel => 'work',
          :country => 'United States of America',
          :formatted_address => "2345 Long Dr. #232\nSomwhere\nIL\n12345\n" \
            "United States of America",
          :city => 'Somwhere',
          :street => '2345 Long Dr. #232',
          :region => 'IL',
          :postcode => '12345'
      },
      {
          :rel => 'home',
          :country => 'United States of America',
          :formatted_address => "123 Far Ln.\nAnywhere\nMO\n67891\n" \
            "United States of America",
          :city => 'Anywhere',
          :street => '123 Far Ln.',
          :region => 'MO',
          :postcode => '67891'
      }
    ]
    expect(@contact_v3.addresses).to eq(formatted_addresses)
  end

  it 'has full phone numbers' do
    expect(@empty.phone_numbers_full).to eq([])
    expect(@contact_v3.phone_numbers_full).to eq([ { :primary => true,
      :number => '(123) 334-5158', :rel => 'mobile' } ])
  end
  it 'has full emails' do
    expect(@empty.emails_full).to eq([])
    expect(@contact_v3.emails_full).to eq([ { :primary => true,
      :address => 'johnsmith@example.com', :rel => 'other' } ])
  end
end
