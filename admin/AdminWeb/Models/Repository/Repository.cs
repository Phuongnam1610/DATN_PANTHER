using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Google.Cloud.Firestore;
using Google.Cloud.Firestore.V1;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace AdminWeb.Models
{
    public interface IIdentifiable
    {
        string id { get; set; }
    }

    public class Repository<T> : IRepository<T> where T : class, IIdentifiable
    {
        protected readonly FirestoreDb _firestoreDb;
        protected readonly CollectionReference collection;

        public Repository(FirestoreDb firestoreDb,string collectionName)
        {
            _firestoreDb = firestoreDb;
            collection = _firestoreDb.Collection(collectionName);
        }

        public async Task AddAsync(T model)
        {
            
            await collection.AddAsync(model);
        }

        public async Task DeleteAsync(string id)
        {
            await collection.Document(id).DeleteAsync();
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            var snapshot = await collection.GetSnapshotAsync();
            var results = new List<T>();
            foreach (var document in snapshot.Documents)
            {
                var data = document.ConvertTo<T>();
                data.id = document.Id;
                results.Add(data);
            }
            return results;
        }

        public async Task<T> GetByIdAsync(string id)
        {
            var document = await collection.Document(id).GetSnapshotAsync();

            if (document.Exists)
            {
                return document.ConvertTo<T>();
            }

            return null; // or throw an exception if preferred
        }

        public async Task UpdateAsync(string id, T model)
        {
            await collection.Document(id).SetAsync(model, SetOptions.MergeAll);
        }
    }
}