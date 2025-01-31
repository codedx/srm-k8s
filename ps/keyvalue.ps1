# KeyValue provides [Tuple`2] functionality w/ support for deserialization and casting
class KeyValue {
	[string] $key
	[string] $value

	KeyValue() {
	}

	KeyValue([string] $key, [string] $value) {
		$this.key = $key
		$this.value = $value
	}

	[Tuple`2[string,string]]ToTuple() {
		return [Tuple`2[string,string]]::new($this.key, $this.value)
	}

	static [KeyValue]New([string] $key, [string] $value) {
		return new-object KeyValue($key, $value)
	}

	[string] ToString() {
		return $this.ToTuple().ToString()
	}
}
