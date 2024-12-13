

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class PromptRepository(FirestoreDb db) : Repository<Prompt>(db,collectionName), IPromptRepository
{
    
    private const string collectionName = "Chatbot";


    public async Task<bool> AddPrompts(Prompt prompt)
    {
   
            DocumentReference docRef = await collection.AddAsync(prompt);
            prompt.id = docRef.Id; // Update the prompt ID if your Prompt class has an Id property
           return true;
    }

    
    public async Task<bool> EditPrompts(Prompt prompt)
    {

            await collection.Document(prompt.id).SetAsync(prompt); // Update the prompt ID if your Prompt class has an Id property
            return true;
        
    }

    public async Task<IEnumerable<Prompt>> GetAllAsync (string searchText)
    {
        var prompts = await GetAllAsync();
        if(searchText!="")
        {
            prompts = prompts.Where(x => x.question.Contains(searchText)||
            x.responses.Contains(searchText));
           
        }
        return prompts;
    }
}