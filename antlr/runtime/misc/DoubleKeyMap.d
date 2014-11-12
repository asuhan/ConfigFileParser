module antlr.runtime.misc.DoubleKeyMap;

//DoubleKeyMap!(int,float,Object) h;


/** Sometimes we need to map a key to a value but key is two pieces of data.
 *  This nested hash table saves creating a single key each time we access
 *  map; avoids mem creation.
 */
public class DoubleKeyMap(Key1, Key2, Value) {
	Value[Key2][Key1] data ;

	public Value put(Key1 k1, Key2 k2, Value v) {
                
                auto data2= k1 in data;
		//Map<Key2, Value> data2 = data.get(k1);
		Value prev = null;
		if ( data2==null ) {
			data[k1][k2]=v;
                        return prev;
		}
		else {
			prev = (*data2)[k2];
		}
		(*data2)[k2]=v;
		return prev;
	}

	public Value get(Key1 k1, Key2 k2) {
		auto data2= k1 in data;
		if ( data2==null ) return null;
		return (*data2)[k2];
	}

	public Value[Key2] get(Key1 k1) { return data[k1]; }

	/** Get all values associated with primary key */
	public Value[] values(Key1 k1) {
		auto data2= k1 in data;
		if ( data2==null ) return null;
		return data2.values();
	}

	/** get all primary keys  as a set*/
	public bool [Key1] keySet() {
                bool [Key1] aset;
                foreach(k;data.keys())
                   aset[k]=true;
		return aset;
	}

	/** get all secondary keys associated with a primary key as a set */
	public bool [Key2] keySet(Key1 k1) {
		auto data2= k1 in data;
		if ( data2==null ) return null;
                bool [Key2] aset;
                foreach(k;data2.keys())
                   aset[k]=true;
		return aset;
	}

	public Value[] values() {
		Value[] s ; 
		foreach (k2 ; data.values()) {
			foreach (Value v ; k2.values()) {
				s~=v;
			}
		}
		return s;
	}
}
