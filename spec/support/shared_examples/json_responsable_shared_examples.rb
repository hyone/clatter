
shared_examples 'json success responsable' do
  it "should include status 'success'" do
    expect(json_response['response']['status']).to eq('success')
  end
end

shared_examples 'json error responsable' do
  it "should include status 'error'" do
    expect(json_response['response']['status']).to eq('error')
  end

  it 'should include error messages' do
    expect(json_response['response']['messages'].size).to be > 0
  end
end
